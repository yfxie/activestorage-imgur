class ActiveStorage::ImgurController < ActiveStorage::DiskController
  def update
    if token = decode_verified_token
      imgur_service.upload token[:key], request.body, checksum: token[:checksum]
      head :no_content
    else
      head :not_found
    end
  rescue ActiveStorage::IntegrityError
    head :unprocessable_entity
  ensure
    response.stream.close
  end

  private
  def imgur_service
    ActiveStorage::Blob.service
  end
end
