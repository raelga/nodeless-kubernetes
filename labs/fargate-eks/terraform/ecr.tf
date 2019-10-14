resource "aws_ecr_repository" "virtual-kubelet" {
  name = "virtual-kubelet"
}

output "virtual_kubelet_repo" {
  value = "${aws_ecr_repository.virtual-kubelet.repository_url}"
}

resource "aws_ecr_repository" "traefik" {
  name = "traefik"
}

output "traefik_repo" {
  value = "${aws_ecr_repository.traefik.repository_url}"
}
