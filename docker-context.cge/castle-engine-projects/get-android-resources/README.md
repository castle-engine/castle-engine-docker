Project to cause download of Gradle + various Android libraries within the Docker image.
Ths makes building Android applications within this Docker image...

- ...faster (well, once you have the Docker image downloaded;
  but you don't need to redownload them in each container you create).

- ...more reliable, as we don't depend on Google servers with Android libs being available.
  Experience from Jenkins shows that sometimes these servers have connection troubles.
