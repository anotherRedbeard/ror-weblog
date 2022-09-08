#create postgresql in Azure
az group create --name red-cus-rubyonrails-rg --location "Central US"

#add the db-up extension
az extension add --name db-up
az postgres up --resource-group red-cus-rubyonrails-rg --location centralus --server-name red-cus-pg-db --database-name ruby_blog_prd --admin-user adminUser --admin-password 3drXwWZ1tV3i --ssl-enforcement Enabled

#update config/database.yml with environment variables for host, database, username, and password
#test is locally by running these commands
rake db:migrate RAILS_ENV=production
rake assets:precompile
#you will need to ensure you only pull the first 16 bytes of the secret and populate the varialbes with it, otherwise it won't work as you will get an error saying the key has to be exactly 16 bytes
rails secret | cut -c 32
#Add rails secret (output from above) to the following environment varialbes
export RAILS_MASTER_KEY=<output-of-rails-secret>
export SECRET_KEY_BASE=<output-of-rails-secret>
#enable environment to serve JavaScript and CSS
export RAILS_SERVE_STATIC_FILES=true

#test out the prod install on dev
rails server -e production

#I had a lot of errors trying to get the encryption and secrets to work.  
#The problem was I was attempting to run the server with the 2 keys above that were larger than 16 bytes. 
#What I finally had to do was to remove the existing /config/credentials.yml.enc file and then run the rails credentials:edit command AFTER I ensured the 2 keys above were 
#exactly 16 bytes

#configure a deployment user
az webapp deployment user set --user-name ruby-deploy --password o28Li_#rKHk

#create app service plan
az appservice plan create --name red-cus-rubyonrails-devops-asp --resource-group red-cus-rubyonrails-rg --sku FREE --is-linux

#create web app
az webapp create --resource-group red-cus-rubyonrails-rg --plan red-cus-rubyonrails-devops-asp --name red-cus-rubyonrails-devops-app --runtime 'RUBY:2.7' --deployment-source-url https://github.com/anotherRedbeard/ror-weblog --deployment-source-branch main

#setup environment variables
az webapp config appsettings set --name red-cus-rubyonrails-devops-app --resource-group red-cus-rubyonrails-rg --settings DB_HOST="red-cus-pg-db.postgres.database.azure.com" DB_DATABASE="ruby_blog_prd" DB_USERNAME="root@<postgres-server-name>" DB_PASSWORD="Ruby_blog_dev1"