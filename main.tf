terraform {
  required_providers {
    docker = {
        source = "kreuzwerker/docker"
        version = "~> 3.0.1"
    }
  }
}

provider "docker" {
    host = "unix:///var/run/docker.sock"
}

resource "docker_image" "ubuntu" {
    name            = "ubuntu:latest"
    keep_locally    = false
}

resource "docker_container" "webserver" {
    image               = docker_image.ubuntu.name #tutorial im following has .latest instead of .name, but that doesn't work?
    name                = "terraform-docker-test"
    must_run            = true
    publish_all_ports   = true
    command = ["tail", "-f", "/dev/null"] #starts the container
}

resource "docker_image" "nginx" {
    name            = "nginx:latest"
    keep_locally    = false
}

resource "local_file" "index" {
    count = var.server_count
    content = "<head><title>Welcome!</title></head><body>Welcome to my website! You are on Server No. ${count.index+1}</body>"
    filename = "/tmp/tutorial/www/server${count.index+1}/index.html"
}

resource "docker_container" "nginx" {
    count = var.server_count
    image   = docker_image.nginx.name 
    name    = "nginx-server-${count.index+1}"
    ports {
        internal = 80
        external = "800${count.index+1}"
    }
    volumes {
        container_path = "/usr/share/nginx/html"
        host_path = "/tmp/tutorial/www/server${count.index+1}"
        read_only = true
    }
}