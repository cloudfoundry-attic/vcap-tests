require 'open3'

ERLANG_VERSION="R14B02"
ERL_VERSION="5.8.3"
ERLANG_TARBALL="otp_src_#{ERLANG_VERSION}.tar.gz"
ERLANG_SOURCE="http://erlang.org/download/#{ERLANG_TARBALL}"
ERLANG_DIR="otp_src_#{ERLANG_VERSION}"
ERLANG_PATH=File.join(Dir.pwd, "runtimes", "erlang", "erlang-#{ERLANG_VERSION}")

ENV['PATH'] = "#{ERLANG_PATH}/bin:#{ENV['PATH']}"

def erlang_installed?
  /#{ERL_VERSION}/ =~ Open3.capture3(%q( erl -version ))[1] ||
    File.exists?(File.join(ERLANG_PATH, "bin", "erl"))
end

def install_erlang
  FileUtils.mkdir_p ERLANG_PATH

  code = <<-EOH
    wget #{ERLANG_SOURCE}
    tar xvzf #{ERLANG_TARBALL}
    cd otp_src_#{ERLANG_VERSION}
    #{File.join(".", "configure")} --prefix=#{ERLANG_PATH} --disable-hipe
    make
    make install
  EOH
  #sh code

  FileUtils.rm_rf ERLANG_TARBALL
  FileUtils.rm_rf "otp_src_#{ERLANG_VERSION}"
end

