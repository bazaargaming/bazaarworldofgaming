class AlertsController < ApplicationController
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
	

	def update
		@alert = Alert.find(params[:id])
		if(@alert.update_attributes(params[:alert]))
			flash[:success] = "Alert was successfully updated!"
		else
			flash[:error] = "Alert could not be updated"
		end
			redirect_to :back
		

	end
	def destroy
		@alert = Alert.find(params[:id]).destroy
		flash[:success] = "Alert Deleted"
		redirect_to :back
	end
end
