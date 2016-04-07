# Go Constinous Delivery Server

The following are the containers used in the docker-compose.yml for the server

| Container | Docker index | Github repo |
| --------- | --------------- | ----------- |
| **gocd-server** | [c12e/gocd-server](https://hub.docker.com/r/c12e/gocd-server/)|[cognitivescale/gocd-server](https://github.com/cognitivescale/gocd-server) |
| **gocd-agent** | [c12e/gocd-agent](https://hub.docker.com/r/c12e/gocd-agent/)|[cognitivescale/gocd-agent](https://github.com/cognitivescale/gocd-agent) |
| **selenium-hub** | [selenium/slenium-hub](https://hub.docker.com/r/selenium/hub/)|[SeleniumHQ/docker-selenium](https://github.com/SeleniumHQ/docker-selenium) |
| **node-chrome** | [selenium/node-chrome](https://hub.docker.com/r/selenium/node-chrome/)|[SeleniumHQ/docker-selenium](https://github.com/SeleniumHQ/docker-selenium) |
| **node-firefox** | [selenium/node-firefox](https://hub.docker.com/r/selenium/node-firefox/)|[SeleniumHQ/docker-selenium](https://github.com/SeleniumHQ/docker-selenium) |
| **consul** | [gliderlabs/consul-server](https://hub.docker.com/r/gliderlabs/consul-server/)| |
| **registrator** | [gliderlabs/registrator](https://hub.docker.com/r/gliderlabs/registrator/)| |
| **vault** | [c12e/vault](https://hub.docker.com/r/c12e/vault)|[cognitivescale/docker-alpine/vault](https://github.com/cognitivescale/docker-alpine) |


## How to use?

1. Install Docker on your directly or via Docker Toolbox
2. Launch consul/vault/registrator
	
		cd docker-alpine/baseband
		docker-compose up -d

3. Connect to the vault container and initialize vault 
		
		docker exec -it vault sh
		vault init
		# Write downs the keys and root token YOU WILL NEED these
		vault unseal KEY1
		vault unseal KEY2
		vault unseal KEY3
		vault status
	You should see that the vault is unsealed at this point
	
4. Writing data to the vault

 		export VAULT_TOKEN=<ROOT/Vault TOKEN from #3>
		vault write PATH KEY=VALUE

Here is a list of known paths/keys for setup in vault

| Path | Key(s) | Description|
|---- | ---| --------|	
| secret/gocd | gitssh | The ssh private key to access github |
| secret/gocd/dockerhub | auth, email | The dockerhub credentials from `docker login` |
| secret/gocd/artifactory | username, password | The artifactory credentials for sbt |
| secret/gocd/npmrc | ???? | The artifactory access token for NPM |
 
*TODO:* simplify the vault+consul script and encode more config in vault to avoid rev'ing the container for each new file.. For example store the file and encode the file name/path.

5. Start the gocd compose file..
 		
 		cd gocd-server
 		export VAULT_TOKEN=<ROOT/Vault TOKEN from #3>
 		docker-compose up -d
 		

	 		
 
 	


    
