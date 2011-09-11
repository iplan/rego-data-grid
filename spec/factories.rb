Factory.define :article do |f|
  f.sequence(:title) {|n| "article - #{n}"}
end
