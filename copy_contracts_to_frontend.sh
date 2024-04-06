# deploy the contracts to ganache
truffle migrate --network development

# remove the contracts folder from the frontend project
rm -rf ./../ecommerce-order-purchasing-frontend/src/contracts/

# copy the contracts folder to the frontend project
cp -r ./build/contracts ./../ecommerce-order-purchasing-frontend/src/