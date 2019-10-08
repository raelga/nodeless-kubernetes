resource "aws_ecr_repository" "virtual-kubelet" {
  name = "virtual-kubelet"
}

output "virtual_kubelet_repo" {
  value = "${aws_ecr_repository.virtual-kubelet.repository_url}"
}
