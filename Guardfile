
guard :test do
  watch(%r{^test/.+_test\.rb$})
  watch('test/test_helper.rb')  { 'test' }

  # Non-rails
  watch(%r{^lib/(.+)\.rb$}) { |m| "test/#{m[1]}_test.rb" }
end
