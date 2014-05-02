class AlertsController < ApplicationController
	#Action to create an Alert
	#Success and error messages present.
	def create	
		@alert =Game.find(params[:game][:id]).alerts.new({:threshold => params[:alert][:threshold],
							:user_id => params[:user][:id]})
		if @alert.save
			flash[:success] = "Alert was successfully created!"
		else
			flash[:error] = "Alert was unable to be created"
		end

		redirect_to :back
	end
	
	#Action to update an alert in the database.
	#Success and error messages present.
	def update
		@alert = Alert.find(params[:id])
		if(@alert.update_attributes(params[:alert]))
			flash[:success] = "Alert was successfully updated!"
		else
			flash[:error] = "Alert could not be updated"
		end
			redirect_to :back
		

	end
	#Action to delete an alert from the database.
	#Success message present.
	def destroy
		@alert = Alert.find(params[:id]).destroy
		flash[:success] = "Alert Deleted"
		redirect_to :back
	end
end
