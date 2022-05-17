PyAV
====

[![GitHub Test Status][github-tests-badge]][github-tests] \
[![Gitter Chat][gitter-badge]][gitter] [![Documentation][docs-badge]][docs] \
[![Python Package Index][pypi-badge]][pypi] [![Conda Forge][conda-badge]][conda]

--------------------------------------
PyAV with custom ffmpeg "hack" for NTP 
--------------------------------------

Prepare custom ffmpeg in docker container
-----------------------------------------
Patched ffmpeg version is 4.1.6
Patch adds following data to AVPacket struct

```c
    uint32_t timestamp;
    uint32_t last_rtcp_ntp_time_l;
    uint32_t last_rtcp_ntp_time_h;
    uint32_t last_rtcp_timestamp;
    uint16_t seq;
    bool synced;
```

Build in docker 20.04 with python 3.8

```bash
cd custom_ffmpeg/ffmpeg.4.1.6
bash ./build.base.patched.image.sh
```
Takes some time, because ffmpeg libs are built too.
This will prepre local container tagged as ffmpeg_patched:4.1.6

Build release of PyAV with custom ffmpeg
--------------------------------

```bash
bash ./av-ntp-ts.build.release.sh
```
final av_ntp_ts-9.2.0-cp38-cp38-linux_x86_64.whl is in ./dist folder

TODO.1
1. final package named as av-ntp-ts, to be different than av
2. thats why it can be published to PyPi as public package 
3. add twine script to publish whl

TODO.2
1. windows build


Explanation
-----------

Packet class (av/packet.pyx) is extended to adress AVPacket data

```python
    property rtcp_synced:
        """
        :type: bint
        """
        def __get__(self):
            return self.ptr.synced


    property rtcp_last_ntp_time_l:
        """
        :type: uint32_t
        """
        def __get__(self):
            return self.ptr.last_rtcp_ntp_time_l

    property rtcp_last_ntp_time_h:
        """
        :type: uint32_t
        """
        def __get__(self):
            return self.ptr.last_rtcp_ntp_time_h


    property rtcp_last_timestamp:
        """
        :type: uint32_t
        """
        def __get__(self):
            return self.ptr.last_rtcp_timestamp

    property rtcp_timestamp:
        """
        :type: uint32_t
        """
        def __get__(self):
            return self.ptr.timestamp

    property rtcp_seq:
        """
        :type: uint16_t
        """
        def __get__(self):
            return self.ptr.seq
```
And can be used directly in code as.

```python
   if packet.rtcp_synced:
        print(
              f'Packet rtcp_last_ntp_time_l {packet.rtcp_last_ntp_time_l} rtcp_last_ntp_time_h {packet.rtcp_last_ntp_time_h}')
        print(f'       rtcp_last_timestamp {packet.rtcp_last_timestamp} rtcp_timestamp {packet.rtcp_timestamp}')
```
Those are "raw" values, and final timestamp can be calculated as follows (fragment from mv-extractor project)

```c++
    // wait for the first RTCP sender report containing RTP timestamp <-> NTP walltime mapping,
    // before this no reliable frame timestmap can be computed
    if (this->is_rtsp && packet.synced) {
        // compute absolute UNIX timestamp for each frame as follows (90 kHz clock as in RTP spec):
        // frame_time_unix = last_rtcp_ntp_time_unix + (timestamp - last_rtcp_timestamp) / 90000
        struct timeval tv;
        ntp2tv(&packet.last_rtcp_ntp_time, &tv);
        double rtp_diff = (double)(packet.timestamp - packet.last_rtcp_timestamp) / 90000.0;
        this->frame_timestamp = (double)tv.tv_sec + (double)tv.tv_usec / 1000000.0 + rtp_diff;
#ifdef DEBUG
        std::cerr << "frame_timestamp (UNIX): " << std::fixed << this->frame_timestamp << std::endl;
#endif
    }
```


--------------------------------------------------------------------


PyAV is a Pythonic binding for the [FFmpeg][ffmpeg] libraries. We aim to provide all of the power and control of the underlying library, but manage the gritty details as much as possible.

PyAV is for direct and precise access to your media via containers, streams, packets, codecs, and frames. It exposes a few transformations of that data, and helps you get your data to/from other packages (e.g. Numpy and Pillow).

This power does come with some responsibility as working with media is horrendously complicated and PyAV can't abstract it away or make all the best decisions for you. If the `ffmpeg` command does the job without you bending over backwards, PyAV is likely going to be more of a hindrance than a help.

But where you can't work without it, PyAV is a critical tool.


Installation
------------

Due to the complexity of the dependencies, PyAV is not always the easiest Python package to install from source. Since release 8.0.0 binary wheels are provided on [PyPI][pypi] for Linux, Mac and Windows linked against a modern FFmpeg. You can install these wheels by running:

```bash
pip install av
```

If you want to use your existing FFmpeg, the source version of PyAV is on [PyPI][pypi] too:

```bash
pip install av --no-binary av
```

Alternative installation methods
--------------------------------

Another way of installing PyAV is via [conda-forge][conda-forge]:

```bash
conda install av -c conda-forge
```

See the [Conda install][conda-install] docs to get started with (mini)Conda.

And if you want to build from the absolute source (for development or testing):

```bash
git clone git@github.com:PyAV-Org/PyAV
cd PyAV
source scripts/activate.sh

# Either install the testing dependencies:
pip install --upgrade -r tests/requirements.txt
# or have it all, including FFmpeg, built/installed for you:
./scripts/build-deps

# Build PyAV.
make
```

---

Have fun, [read the docs][docs], [come chat with us][gitter], and good luck!



[conda-badge]: https://img.shields.io/conda/vn/conda-forge/av.svg?colorB=CCB39A
[conda]: https://anaconda.org/conda-forge/av
[docs-badge]: https://img.shields.io/badge/docs-on%20pyav.org-blue.svg
[docs]: http://pyav.org/docs
[gitter-badge]: https://img.shields.io/gitter/room/nwjs/nw.js.svg?logo=gitter&colorB=cc2b5e
[gitter]: https://gitter.im/PyAV-Org
[pypi-badge]: https://img.shields.io/pypi/v/av.svg?colorB=CCB39A
[pypi]: https://pypi.org/project/av

[github-tests-badge]: https://github.com/PyAV-Org/PyAV/workflows/tests/badge.svg
[github-tests]: https://github.com/PyAV-Org/PyAV/actions?workflow=tests
[github]: https://github.com/PyAV-Org/PyAV

[ffmpeg]: http://ffmpeg.org/
[conda-forge]: https://conda-forge.github.io/
[conda-install]: https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html
