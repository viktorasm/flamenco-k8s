## Notes

* manager can't run without detecting blender installation: should probably not care about it
* file-based configuration not as comfortable for some settings like configuring `shared_storage_path`: would be much easier to just feed into container as env var.
* downscaling workers did not register well on manager
* manager should run in a mode where unhealthy workers are just removed
* flamenco bug: selecting tasks in UI makes them jump around



## TODO:

* setup autoscaling! main goal of this exercise
* include ffmpeg
  
* IAC: automate SA creation
* IAC: automate bucket creation
* helm charts: review for hardcoded settings, like bucket name
* script to reapply helm
* script to download Docker dependencies (blender, flamenco)

## Done:
* initial infrastructure automation to provision/destroy everything
* manager needs to start in ready-to-work setup without any introductory dialog.
