## About

This is a cloud configuration to run https://flamenco.blender.org/ with as many compute power as you can buy, as opposed to owning physical computers.

The theoretical goals would be:
* When time is of the essence, you'd prefer to just have a very big render farm for short period of time;
* Use cheapest compute power there is in the cloud - spot instances. 
* When no jobs are running, just scale down and don't pay a dime.

Of course, there are many cloud-based render services, but prices are outrageous - let's see if on-demand provisioning and cheap throaway setup can do better.


### Architecture

Probably mumbo-jumbo to 3d folks, but listing the main idea anyway:

* Create docker containers for flamenco-worker and flamenco-manager; bundle blender together with docker.
* Containers running in Kubernetes (chose Google GKE as google cloud provides best per-project isolation, easy to teardown)
* All worker nodes in Kubernetes configured as spots
* Blender scenes are stored in GCS (cloud storage) bucket; containers mount that as file system volume.
* using GCS (cloud storage) bucket for transfering scenes
* User uploads scenes to GCS bucket, and runs a local http proxy to reach manager on the cloud to view status.

```mermaid
graph TB
    subgraph k8s["Kubernetes Cluster (GKE)"]
        subgraph spotInstances["Spot instances"]
            FlamencoWorker[Flamenco Worker]
            FlamencoManager[Flamenco Manager]
            Blender[Blender]
        end
    end
    GCSBucket[GCS : assets storage]
    User[User]
    KubectlProxy[Command-line proxy]
    TF[Terraform]
    User -- Uploads scenes --> GCSBucket
    User -- View manager console --> KubectlProxy 
    User -- Provision and destroy the whole setup -->TF
    TF -- Create/Destroy -->k8s
    KubectlProxy --> FlamencoManager
    User -- Manually scale workers --> FlamencoWorker
    FlamencoWorker -- Mount as Volume --> GCSBucket
    FlamencoManager -- Distribute Jobs --> FlamencoWorker
    Kubernetes -- trigger additional nodes to fit workers --> spotInstances
    FlamencoWorker -- run --> Blender
    Blender -- Access Scenes --> GCSBucket
```



This is a very crude experiment, making this public just to share with a few people.

## Usage

In it's current form, this is not a comprehensive checklist or an end-user journey, but more of an idea to test the setup.

* Create new GCP project
  * https://console.cloud.google.com/
  * Might need to boost quota for "n2d CPUs" right away, defaults are way to small for bursty workloads.
  * Configure credit card etc.
* Install prerequisites
  * https://taskfile.dev/ to use Taskfile targets 
  * Gcloud
  * Terraform
  * Helm
  * kubectl
* Deploy infrastructure
  * go to `deployment/infrastructure`
  * configure `terraform.tfvars` with project_id, and optional overrides for new infrastructure
  * `terraform init`
  * `terraform apply`
  * twist and push various knobs and buttons in GCP console until everything.
* Upload your blend files to assets repo via GCP console or `gsutil`
  * https://console.cloud.google.com/storage/browser/YOUR-BUCKET-NAME
* Access the manager and submit a render job - from main dir:
  * `task`: list all available tasks
  * `tak proxy`: open proxy to manager and inspect the setup
  *  `task workers-many`: scale to more workers. should trigger autoscaling of infrastructure, observe the process in GCP console and fix issues with more knobs and buttons;
  * `task debug-job`: submit a job to manager; proxy should be running in another terminal.
 * Destroy infrastructure:
   * Once you're done using things, destroy everything with `task tf-destroy`. If that fails, e.g. you lose your TF state or something - drop the whole project manually in GCP console.


## Notes

* manager can't run without detecting blender installation: should probably not care about it
* file-based configuration not as comfortable for some settings like configuring `shared_storage_path`: would be much easier to just feed into container as env var.
* downscaling workers did not register well on manager
* manager should run in a mode where unhealthy workers are just removed
* flamenco bug: selecting tasks in UI makes them jump around



## TODO:

* helm charts: review for hardcoded settings, like bucket name

* setup automatic worker autoscaling based on incoming work. might need manager tweaks for this
  * HPA on workers might be too indirect
  * explore custom KEDA scaler option
  * explore custom operator option

* IAC: automate SA creation
* IAC: automate bucket creation
* IAC: with terraform destroy, we'll drop bucket & service account, which probably stick around

* manager: do not run on spot. create small machine just for manager.
* worker memory: different jobs require different memory, might need a more dynamic way to set this.
* worker: if manager is unreachable, just die.
  * maybe possible via health probe?
* include ffmpeg
* script to reapply helm
* script to download Docker dependencies (blender, flamenco)

## Done:
* initial infrastructure automation to provision/destroy everything
* manager needs to start in ready-to-work setup without any introductory dialog.
