require 'rails_pdf'
Mime::Type.register "application/pdf", :pdf
ActionView::Template.register_template_handler 'writer', RailsPDF::TemplateHandler::Base
ActionController::Base.send :include, RailsPDF::ControllerExtensions