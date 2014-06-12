require 'yt/models/resource'

module Yt
  module Models
    # Provides methods to interact with YouTube playlists.
    # @see https://developers.google.com/youtube/v3/docs/playlists
    class Playlist < Resource

      # @!attribute playlist_items
      #   @return [Yt::Collections::PlaylistItems] the playlist’s items.
      has_many :playlist_items

      def delete
        do_delete {@id = nil}
        !exists?
      end

      def update(options = {})
        options[:title] ||= title
        options[:description] ||= description
        options[:tags] ||= tags
        options[:privacy_status] ||= privacy_status

        snippet = options.slice :title, :description, :tags
        status = {privacyStatus: options[:privacy_status]}
        body = {id: @id, snippet: snippet, status: status}

        do_update(params: {part: 'snippet,status'}, body: body) do |data|
          @id = data['id']
          @snippet = Snippet.new data: data['snippet'] if data['snippet']
          @status = Status.new data: data['status'] if data['status']
          true
        end
      end

      def exists?
        !@id.nil?
      end

      def add_video(video_id)
        playlist_items.insert video_params(video_id), ignore_errors: true
      end

      def add_video!(video_id)
        playlist_items.insert video_params(video_id)
      end

      def add_videos(video_ids = [])
        video_ids.map{|video_id| add_video video_id}
      end

      def add_videos!(video_ids = [])
        video_ids.map{|video_id| add_video! video_id}
      end

      def delete_playlist_items(attrs = {})
        playlist_items.delete_all attrs
      end

    private

      def delete_params
        super.tap do |params|
          params[:path] = '/youtube/v3/playlists'
          params[:params] = {id: @id}
        end
      end

      def update_params
        super.tap do |params|
          params[:path] = '/youtube/v3/playlists'
          params[:body_type] = :json
          params[:expected_response] = Net::HTTPOK
        end
      end

      def video_params(video_id)
        {id: video_id, kind: :video}
      end
    end
  end
end