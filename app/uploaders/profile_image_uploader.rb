# encoding: utf-8

class ProfileImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  case
  # AWS S3
  when Rails.application.secrets.aws_access_key_id
    storage :fog
  else
    storage :file
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    base = 'default_profile_image.jpg'
    '/images/' +
      if version_name.blank?
        base
      else
        "#{version_name}_#{base}"
      end
  end

  process resize_to_fill: [400, 400]

  version :small do
    process resize_to_fill: [48, 48]
  end

  version :normal do
    process resize_to_fill: [150, 150]
  end

  # version :big do
    # process resize_to_fill: [400, 400]
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.

  # using unique identifier as filename
  def filename
    "#{secure_token}.#{file.extension}" if original_filename
  end

  protected
  def secure_token
    v = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(v) or model.instance_variable_set(v, SecureRandom.uuid)
  end
end
