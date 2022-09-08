#create postgresql in Azure
az group create --name red-cus-rubyonrails-rg --location "Central US"

#add the db-up extension
az extension add --name db-up
az postgres up --resource-group red-cus-rubyonrails-rg --location centralus --server-name red-cus-pg-db --database-name ruby_blog_prd --admin-user adminUser --admin-password 3drXwWZ1tV3i --ssl-enforcement Enabled