output "name" {
  value = "${module.mysql.db_name}"
}

output "address" {
  value = "${module.mysql.address}"
}

output "port" {
  value = "${module.mysql.port}"
}