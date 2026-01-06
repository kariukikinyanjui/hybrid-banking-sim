# The Database Instance
resource "aws_db_instance" "wallet_db" {
  identifier        = "safari-wallet-db"
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "postgres"
  engine_version    = "13"
  instance_class    = "db.t3.micro"
  db_name           = "walletdb"
  
  # CREDENTIALS
  # Security Note: In production, use AWS Secrets Manager. 
  # For this simulation, we hardcode to keep the demo self-contained.
  username          = "admin_user"
  password          = "SuperSecurePass123!"

  # LOCALSTACK SPECIFICS
  # 1. Skip snapshots: We don't need backups of a simulation that dies when we close Docker.
  skip_final_snapshot = true
  
  # 2. Network: Put it in our VPC
  vpc_security_group_ids = [aws_security_group.internal_trust.id]
  
  # Note: Real AWS requires a 'db_subnet_group'. LocalStack is lenient and allows
  # launching without it, placing it in the default VPC subnets if not specified.
  # For strict realism, we could add one, but we'll keep it simple for now.
}
