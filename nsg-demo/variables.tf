variable "location" {
  default = "centralus"
}

variable "ssh_public_key_path" {
  description = "Path to your SSH public key (e.g., ~/.ssh/id_rsa.pub)"
  default     = "~/.ssh/id_rsa.pub"
}
