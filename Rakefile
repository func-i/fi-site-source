desc "compile and run the site"
task :default do
  pids = [
    spawn("jekyll serve -w --host 0.0.0.0") # put `auto: true` in your _config.yml
  ]

  trap "INT" do
    Process.kill "INT", *pids
    exit 1
  end

  loop do
    sleep 1
  end
end
