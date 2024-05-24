class DocsController < ApplicationController
    before_action :require_login
    skip_before_action :require_login, only: [:get], :raise => false

    def get
        @doc = find_doc(doc_params[:id])
    end

    def edit
        @doc = find_user_doc(doc_params[:id])
        @all_folders = Folder.where(user_id: current_user.id)
    end

    def new
        @folder_id = doc_params[:folder_id]
    end

    def save
        dp = doc_params
        if dp[:id]
            update_doc(find_user_doc(dp[:id]), dp)
        else
            update_doc(new_doc(params), dp)
        end
    end

    def destroy
        Document.destroy(params[:id])
        redirect_to root_path
    end

private
    def find_doc id
        d = Document.find(id) || not_found
        u = User.find(d.user_id) || not_found

        if current_user and current_user.id == d.user_id
            return d
        end

        not_found if u.private

        return d
    end

    def find_user_doc id
        not_found if not current_user
        Document.find_by(id: id, user_id: current_user.id) || not_found
    end

    def new_doc params
        return Document.new(user_id: current_user.id)
    end

    def update_doc doc, pars
        doc.name = pars[:name] if pars[:name]
        doc.data = pars[:data] if pars[:data]
        doc.folder_id = pars[:folder_id] if pars[:folder_id]
        if doc.save
            redirect_to "/docs/#{doc.id}"
        else
            internal_error
        end
    end

    def doc_params
        begin
            Integer(params[:id]) if params[:id]
            Integer(params[:folder_id]) if params[:folder_id]
            if params[:name]
                bad_request if params[:name].length == 0
                bad_request if params[:name].length > Rails.application.config.max_document_name_length
            end
            if params[:data]
                bad_request if params[:data].length > Rails.application.config.max_document_length
            end
        rescue
            bad_request
        end

        return params.permit(:id, :folder_id, :name, :data)
    end
end
