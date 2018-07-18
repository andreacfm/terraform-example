variable "server_port" {
  description = "Server port"
  default     = 8080
}

variable "cluster_name" {}
variable "db_remote_state_bucket" {}
variable "db_remote_state_key" {}
variable "instance_type" {}
variable "min_size" {}
variable "max_size" {}
