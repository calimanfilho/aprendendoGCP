provider "google" {
  project       = "calimanfilho.com"
  region        = "us-central1"
  zone          = "us-central1-c"
  credentials   = "${file("serviceaccount.yaml")}"
}

resource "google_folder" "Comercial" {
  display_name  = "Comercial"
  parent        = "organizations/454753657896"
}

resource "google_folder" "Mobile" {
  display_name  = "Mobile"
  parent        = google_folder.Comercial.name
}

resource "google_folder" "Desenvolvimento" {
  display_name  = "Desenvolvimento"
  parent        = google_folder.Mobile.name
}

resource "google_folder" "Producao" {
  display_name  = "Producao"
  parent        = google_folder.Mobile.name
}

resource "google_folder" "Financeira" {
  display_name  = "Financeira"
  parent        = "organizations/454753657896"
}

resource "google_folder" "WebApp" {
  display_name  = "WebApp"
  parent        = google_folder.Financeira.name
}

resource "google_folder" "Desenvolvimento" {
  display_name  = "Desenvolvimento"
  parent        = google_folder.WebApp.name
}

resource "google_folder" "Producao" {
  display_name  = "Producao"
  parent        = google_folder.WebApp.name
}

resource "google_project" "calimanfilho-comercial-mobile-dev" {
  name          = "comercial-mobile-dev"
  project_id    = "calimanfilho-comercial-mobile-dev"
  folder_id     = google_folder.Desenvolvimento.name
  auto_create_network = false
  billing_account = "018973-A8340F-83D8E5"
}

resource "google_project" "calimanfilho-comercial-mobile-prod" {
  name          = "comercial-mobile-prod"
  project_id    = "calimanfilho-comercial-mobile-prod"
  folder_id     = google_folder.Producao.name
  auto_create_network = false
  billing_account = "018973-A8340F-83D8E5"
}

resource "google_project" "calimanfilho-financeira-webapp-dev" {
  name          = "financeira-webapp-dev"
  project_id    = "calimanfilho-financeira-webapp-dev"
  folder_id     = google_folder.Desenvolvimento.name
  auto_create_network = false
  billing_account = "018973-A8340F-83D8E5"
}

resource "google_project" "calimanfilho-financeira-webapp-prod" {
  name          = "financeira-webapp-prod"
  project_id    = "calimanfilho-financeira-webapp-prod"
  folder_id     = google_folder.Producao.name
  auto_create_network = false
  billing_account = "018973-A8340F-83D8E5"
}