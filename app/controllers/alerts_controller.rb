class AlertsController < ApplicationController
	def create
		flash[:success] = "Alert was successfully created!"
		redirect root_path
	end
	

	def update
		@alert = Alert.find(params[:id])

		if(@alert.update_attributes(params[:alert]))
			redirect_to :back
		end

	end
	def destroy
		@alert = Alert.find(params[:id]).destroy
		flash[:success] = "Alert Deleted"
		redirect_to :back
	end
end
