output "pipe_name" {
  value = snowflake_pipe.this.name
}

output "pipe_channel" {
  value = snowflake_pipe.this.notification_channel
}