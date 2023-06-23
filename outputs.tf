output "success" {
    description = "If launching the servers is successful. If not, tries to tell why"
    value       = length(docker_container.nginx) > 9 ? "Too many servers. Program supports a max of 9" : "Servers created successfully"
}