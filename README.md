## About

This configuration enables running [Flamenco](https://flamenco.blender.org/) in the cloud, leveraging as much computing power as you can afford, instead of relying on physical computers.

The theoretical goals include:
* Having a large render farm at your disposal for a short period when time is critical.
* Utilizing the most affordable compute power available in the cloud, specifically spot instances.
* Scaling down to zero cost when there are no active jobs.

Although numerous cloud-based render services exist, they often come with exorbitant fees. This project aims to explore whether on-demand provisioning and an economical, disposable setup can offer a more cost-effective solution.

### Architecture

This might be too much technical jargon to those not familiar with clouds&infrastructure, but here is the main concept:

* Flamenco Worker and Flamenco Manager are packaged as Docker containers, bundled with Blender as well.
* Containers are executed in Kubernetes; this project setup uses Google's GKE for its superior per-project isolation and straightforward teardown process.
* Use spot instances for maximum cost savings.
* Use CPU rendering for simplicity of this proof-of-concept. GPU rendering not explored yet, but definitely a possibility, but comes with significant overhead for containers and cost/benefit ratio is unclear;
* Assets (e.g. Blender scenes) are uploaded and stored in a GCS (Google Cloud Storage) bucket, with containers mounting it as a filesystem volume.
* Users use a local HTTP proxy to communicate with the manager in the cloud.


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

In its current form, this is not a comprehensive checklist or an end-user guide, but rather an outline to test the setup.

* Create a new GCP project
  * Start by visiting [Google Cloud Console](https://console.cloud.google.com/)
  * You may need to increase the quota for "n2d CPUs" immediately, as the default limits are too low for bursty workloads.
  * Set up payment.
* Install prerequisites
  * [Taskfile](https://taskfile.dev/) to utilize Taskfile targets.
  * Install Gcloud, Terraform, Helm, and kubectl.
* Deploy infrastructure
  * Navigate to `deployment/infrastructure`.
  * Configure `terraform.tfvars` with your project_id and any optional overrides for new infrastructure.
  * Run `terraform init` and `terraform apply`.
  * Twist and push various knobs and buttons in the GCP console until everything works properly.
* Upload your Blender files to the assets repository via GCP console or `gsutil`
  * Access the [GCS Storage Browser](https://console.cloud.google.com/storage/browser/YOUR-BUCKET-NAME).
* Access the manager and submit a render job from the main directory:
  * Run `task` to list all available tasks.
  * Use `task proxy` to open a proxy to the manager and inspect the setup.
  * Execute `task workers-many` to scale up to more workers. This should trigger autoscaling of the infrastructure. Monitor the process in the GCP console and fix issues with more knobs and buttons.
  * Use `task debug-job` to submit a job to the manager. Ensure the proxy is running in another terminal.
* Destroy infrastructure:
   * After usage, dismantle everything using `task tf-destroy`. If this fails, for example, due to loss of your Terraform state, manually delete the entire project in the GCP console.



## Assorted Notes

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
