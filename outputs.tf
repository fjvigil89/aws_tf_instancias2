output "micro_service_dns" {
  description = "ages_chile"
  value       = aws_eip.microservice.public_dns
}

output "apicapel_dns" {
  description = "Api Capel ages_chile"
  value       = aws_eip.apicapel.public_dns
}