class API < Grape::API
  prefix 'api'
  version 'v1', using: :path
  mount ApiHelpers::BacktestingHelper
  mount ApiHelpers::JSendErrorFormatterHelper
  mount ApiHelpers::JSendSuccessFormatterHelper
  mount Risk::Data
  mount AreasByRisk::Data
  mount ModelsByRisk::Data
  mount Model::Data
  mount Type::Data
  mount Kind::Data
  mount Backtest::Data
  mount Len::Data
  mount Report::Data
  mount Config::Data
end