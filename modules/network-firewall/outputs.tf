output "arn" {
  description = "The ARN of the firewall."
  value       = aws_networkfirewall_firewall.this.arn
}

output "id" {
  description = "The ID of the firewall."
  value       = aws_networkfirewall_firewall.this.id
}

output "name" {
  description = "The name of the firewall."
  value       = aws_networkfirewall_firewall.this.name
}

output "description" {
  description = "The description of the firewall."
  value       = aws_networkfirewall_firewall.this.description
}

output "test" {
  description = "The type of the secret."
  value       = aws_networkfirewall_firewall.this.firewall_status
}

output "test2" {
  description = "The type of the secret."
  value       = aws_networkfirewall_firewall.this.update_token
}
