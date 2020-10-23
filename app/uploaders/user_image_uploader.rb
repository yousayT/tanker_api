# frozen_string_literal: true

class UserImageUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  if Rails.env.production?
    storage :fog
    # Provide a default URL as a default if there hasn't been a file uploaded:
    def default_url
      # For Rails 3.1+ asset pipeline compatibility:
      # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
      "https://tanker-user-image.s3.amazonaws.com/images/fallback/#{[version_name, 'default.png'].compact.join('_')}"
    end
  else
    storage :file
    def default_url
      "/images/fallback/#{[version_name, 'default.png'].compact.join('_')}"
    end
  end

  if Rails.env.production?
    CarrierWave.configure do |config|
      config.fog_credentials = {
        # Amazon S3のための設定
        provider: 'AWS',
        region: ENV['S3_REGION'],
        aws_access_key_id: ENV['S3_ACCESS_KEY'],
        aws_secret_access_key: ENV['S3_SECRET_KEY']
      }
      config.fog_directory = ENV['S3_BUCKET']
    end
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  # def scale(width, height)
  #   do something
  # end
  process resize_to_fill: [100, 100]

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def content_type_whitelist
    %r{image/}
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "#{SecureRandom.uuid}.jpg" if original_filename.present?
  # end
end
