1. Link to github repository for gcp account

https://github.com/dobrozhan/dobrozhan.github.io

2. Commands to set up folder, project and service account

gcloud auth login dobrozhan.oleksandr@dobrozhan.github.io

gcloud organizations list

ID=791825585860

gcloud organizations add-iam-policy-binding 791825585860 --member=user:dobrozhan.oleksandr@dobrozhan.github.io --role=roles/resourcemanager.folderAdmin

gcloud alpha resource-manager folders create --display-name=gcp_training_root --organization 791825585860

gcloud projects create seed-project-dobrozhan --folder=628265103286

gcloud config set project seed-project-dobrozhan

gcloud alpha billing accounts list

ID=0193AC-BC8CBC-0C606B

git clone https://github.com/terraform-google-modules/terraform-google-project-factory

cd terraform-google-project-factory/helpers

setup-sa.sh -o 791825585860 -p seed-project-dobrozhan -b 0193AC-BC8CBC-0C606B -f 628265103286

3. Link to result of working dir in CLI and on Google web interface



4. Credentials file (node that I clear private_key_id, private_key, client_x509_cert_url to XXX)

{
  "type": "service_account",
  "project_id": "seed-project-dobrozhan",
  "private_key_id": "XXX",
  "private_key": "XXX",
  "client_email": "project-factory-28896@seed-project-dobrozhan.iam.gserviceaccount.com",
  "client_id": "107103943195881163316",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "XXX"
}

