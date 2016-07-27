class API < Grape::API
  prefix 'api'
  version 'v1', using: :path
  mount Type::Data
  mount Kind::Data
  mount Risk::Data
  mount AreasByRisk::Data

end