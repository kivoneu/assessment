# outputs.tf

output "load_balancer_ip" {
  value       = google_compute_global_forwarding_rule.web_server.ip_address
  description = "Publiczny adres IP Load Balancera"
}

output "database_connection" {
  value       = google_sql_database_instance.db.connection_name
  description = "Nazwa połączenia instancji Cloud SQL"
}

output "storage_bucket" {
  value       = google_storage_bucket.webapp_storage.url
  description = "URL bucketu Google Cloud Storage"
}
