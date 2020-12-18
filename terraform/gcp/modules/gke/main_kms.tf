
# Need a random string since you can't delete a ring and this stuffs Terraform
resource "random_string" "cluster_key_ring" {
  length  = 16
  lower   = true
  upper   = false
  number  = false
  special = false
}

resource "google_kms_key_ring" "cluster" {
  name     = "cluster-keyring-${random_string.cluster_key_ring.result}"
  location = var.region
}


# Likewise Key
resource "random_string" "cluster_key" {
  length  = 16
  lower   = true
  upper   = false
  number  = false
  special = false
}

resource "google_kms_crypto_key" "cluster" {
  name            = "cluster-key-${random_string.cluster_key.result}"
  purpose         = "ENCRYPT_DECRYPT"
  key_ring        = google_kms_key_ring.cluster.id
  rotation_period = "100000s"
}


resource "google_kms_crypto_key_iam_binding" "cluster" {
  crypto_key_id = google_kms_crypto_key.cluster.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  members = [
    "serviceAccount:${google_service_account.cluster.email}",
    "serviceAccount:service-${data.google_project.kl.number}@container-engine-robot.iam.gserviceaccount.com"
  ]
}