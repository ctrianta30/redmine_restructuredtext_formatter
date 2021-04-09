RedmineApp::Application.routes.draw do
    match '/issues/:id', :controller => 'previews', :via => [:post], :action => 'text'
    match '/projects/:project_id/wiki/:id/edit', :controller => 'wiki', :via => [:post], :action => 'preview'
end

