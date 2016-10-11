require 'spec_helper'

describe "wordpress" do
  let(:node) { 'test.example.com' }

  context "on RedHat" do
    let(:facts) { {
      :osfamily => 'RedHat',
    } }

    it { is_expected.to compile.with_all_deps }
  end

  context "on Debian" do
    let(:facts) { {
      :osfamily => 'Debian',
    } }

    it { is_expected.to compile.with_all_deps }
  end

  context "on Windows" do
    let(:facts) { {
        :osfamily => 'Windows',
    } }

    it { is_expected.to raise_error(Puppet::Error) }
  end

end
