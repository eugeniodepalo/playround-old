Factory.define :round, :class => Round do |round|
  round.people 10
  round.association :arena
  round.association :game
  round.association :user
  round.date Time.now + 2.months
end

Factory.define :approved_round, :class => Round do |round|
  round.people 10
  round.association :arena
  round.association :game
  round.association :user
  round.date Time.now + 2.months
  round.state 'approved'
end