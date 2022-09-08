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
rails secret | wc -c 32
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