class API < Grape::API
  prefix 'api'
  version 'v1', using: :path
  mount Risk::Data
  mount AreasByRisk::Data
  mount ModelsByRisk::Data
  mount Model::Data
  mount Type::Data
  mount Kind::Data
  mount Backtest::Data
end