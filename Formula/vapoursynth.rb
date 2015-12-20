require "formula"

class Vapoursynth < Formula
  desc "Video processing framework with simplicity in mind"
  url "https://github.com/vapoursynth/vapoursynth/archive/R29.tar.gz"
  sha1 "b756a044f7843c0bfbe412a4c533864cdcf94602"
  homepage "http://www.vapoursynth.com"
  head "https://github.com/vapoursynth/vapoursynth.git"

  needs :cxx11
  depends_on "pkg-config" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "yasm" => :build
  depends_on :python3

  depends_on "zimg"
  depends_on "tesseract"
  depends_on "libass"

  resource "cython" do
    url "https://pypi.python.org/packages/source/C/Cython/Cython-0.21.2.tar.gz"
    md5 "d21adb870c75680dc857cd05d41046a4"
    sha1 "c3fe3dd5693aa09719ee4a3bcec898068c82592d"
  end

  def install
    ENV.prepend_create_path "PKG_CONFIG_PATH", python_pkg_config_path
    ENV.prepend_create_path "PYTHONPATH", site_packages
    ENV.prepend_create_path "PATH", libexec/"bin"
    python_install("cython")
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make install"
  end

  private

  def site_packages
    python_version = Language::Python.major_minor_version("python3")
    libexec/"lib/python#{python_version}/site-packages"
  end

  def python_pkg_config_path
    Pathname.new(`python3-config --prefix`.chomp)/"lib/pkgconfig"
  end

  def python_install(package)
    resource(package).stage do
      system "python3", *Language::Python.setup_install_args(libexec)
    end
  end
end
