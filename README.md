## Notes

* manager can't run without detecting blender installation
* manager needs to start in ready-to-work setup without any introductory dialog.
* file-based configuration not as comfortable for some settings like configuring `shared_storage_path`: would be much easier to just feed into container as env var.
* downscaling workers did not register well on manager
* manager should run in a mode where unhealthy workers are just removed


## TODO:

* GCP script to automatically provision:
  * cluster
  * gcr
  * filestore
  * enable fuse driver: gcloud container clusters update flamenco-cluster-1 --project flamenco-experiment --region europe-central2 --update-addons GcsFuseCsiDriver=ENABLED

* provision service account as per:
  https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/cloud-storage-fuse-csi-driver


```
gcloud iam service-accounts create flamenco-user \
    --project=flamenco-experiment
gcloud storage buckets add-iam-policy-binding gs://flamenco-assets-repo \
    --member "serviceAccount:flamenco-user@flamenco-experiment.iam.gserviceaccount.com" \
    --role "roles/storage.objectViewer"
gcloud storage buckets add-iam-policy-binding gs://flamenco-assets-repo \
    --member "serviceAccount:681213112665-compute@developer.gserviceaccount.com" \
    --role "roles/storage.objectViewer"
   
   
gcloud iam service-accounts add-iam-policy-binding flamenco-user@flamenco-experiment.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:flamenco-experiment.svc.id.goog[default/flamenco-user]" 
    
```


https://github.com/GoogleCloudPlatform/gcs-fuse-csi-driver/blob/main/docs/authentication.md
https://github.com/GoogleCloudPlatform/gcs-fuse-csi-driver/blob/main/docs/troubleshooting.md
```
Pod event warning: MountVolume.SetUp failed for volume "xxx" : rpc error: code = Unauthenticated desc = failed to prepare storage service: storage service manager failed to setup service: timed out waiting for the condition

After you follow the documentation Configure access to Cloud Storage buckets using GKE Workload Identity to configure the Kubernetes service account, it usually takes a few minutes for the credentials being propagated. Whenever the credentials are propagated into the Kubernetes cluster, this warning will disappear, and your Pod scheduling should continue. If you still see this warning after 5 minutes, please double check the documentation Configure access to Cloud Storage buckets using GKE Workload Identity to make sure your Kubernetes service account is set up correctly. Make sure your workload Pod is using the Kubernetes service account in the same namespace.
```
