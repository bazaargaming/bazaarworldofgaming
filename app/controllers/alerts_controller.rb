class AlertsController < ApplicationController
	def create
		flash[:success] = "Alert was successfully created!"
		redirect root_path
	end
end
