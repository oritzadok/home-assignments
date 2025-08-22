## Assignment

   
Develop a simple system, that manages a list of restaurants and their properties. e.g. address, style (Italian, French, Korean), vegetarian (yes/no), opening hours, does deliveries, etc.  
The system will have an API for querying with a subset of these parameters and return a recommendation for a restaurant that answers the criteria, including the time of the request to check if its open.  
e.g.  
“A vegetarian Italian restaurant that is open now”  this should return a json object with the restaurant and all its properties:  
{  
   restaurantRecommendation :  
   {  
    	name: ‘Pizza hut’,  
    	style: ‘Italian’,  
    	address: ‘wherever street 99, somewhere’,  
    	openHour: 09:00,  
    	clouseHour: 23:00,  
    	vegetarian : yes  
   }  
}

### Requirements

* The assignment submission should be done in a GIT repo that we can access, could be yours or a dedicated one.  
* Please include all code required to set up the system .  
* The system must be cloud native, with a preference for Azure, but also GCP or AWS are an option, with a simple architecture that will require minimal amount of maintenance.  
* The system should be written in full IaC style, I should be able to fully deploy it on my own cloud instance without making manual changes. Use Terraform for configuring the required cloud resources.  
* There should be some backend storage mechanism that holds the history of all requests and returned responses.  
* Consider that the backend data stored is highly confidential.  
* Make sure the system is secure, however there is no need for the user to authenticate with the system (Assume its a free public service)  
* The system code should be deployed using an automatic CI CD pipeline following any code change, including when adding or updating restaurants.

