#!/bin/bash

# Run the terraform apply command in a loop until it succeeds
while true; do
	    # Execute terraform apply with auto-approve
	        terraform apply -auto-approve
		    
		    # Check if the last command was successful
		        if [ $? -eq 0 ]; then
				        echo "Terraform apply succeeded."
					        break
						    else
							            echo "Terraform apply failed. Retrying..."
								        fi
									    
									    # Optional: You can add a delay before retrying if you want
									    sleep 5
									done

