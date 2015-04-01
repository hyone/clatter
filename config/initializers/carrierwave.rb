if Rails.application.secrets.aws_access_key_id
  CarrierWave.configure do |config|
    config.fog_credentials = {
      provider: 'AWS',
      aws_access_key_id: Rails.application.secrets.aws_access_key_id,
      aws_secret_access_key: Rails.application.secrets.aws_secret_access_key,
      region: Rails.application.secrets.aws_region
    }
    config.fog_public     = true
    config.fog_attributes = { 'Cache-Control' => "public, max-age=#{ 365.days.to_i }" }
    config.fog_directory  = Rails.application.secrets.aws_s3_bucket_name
    # config.asset_host    = Rails.application.secrets.aws_s3_asset_host
  end
end
