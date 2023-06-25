---
title: "Creating a torrent"
date: 2022-11-01T13:05:36+01:00
draft: false
tags: ['torrent']
---
To make a `.torrent` file using the command line, execute the following command:

``` bash
mktorrent -v -p -a http://tracker.url -o filename.torrent folder_name
```

- `-v` is for verbose
- `-p` is for private, as in not DTH or PeerExchange
- `-a` is for the tracker URL
- `-o` is for the output file name

**Important!** The command needs to be all in one line, and quotes must be used around the folder name if it contains spaces.

For example, if you want to make a torrent for exampletracker.com from the data in the "Linux Iso directory" directory you already have on your server at `~/torrents/completed/Linux Iso directory`, you would navigate to the parent directory to make your torrent. Type the following command:

``` bash
cd ~/torrents/completed
```

Then type the following command:

``` bash
mktorrent -v -p -a http://tracker.exampletracker.com:34000/xxxXXXxxx/announce -o VA-Summer_Trance_2009.torrent "Linux Iso directory"
```

Please note that you must use quotes if the target directory name contains spaces.

If you want to specify the piece size for the torrent, you can use the `-l` switch (small L). The piece size is a power of 2. Here are some examples:

- 2<sup>19</sup> = 524,288 = 512 KiB (for file sizes between 512 MiB - 1024 MiB)
- 2<sup>20</sup> = 1,048,576 = 1024 KiB (for file sizes between 1 GiB - 2 GiB)
- 2<sup>21</sup> = 2,097,152 = 2048 KiB (for file sizes between 2 GiB - 4 GiB)
- 2<sup>22</sup> = 4,194,304 = 4096 KiB (for file sizes between 4 GiB - 8 GiB)
- 2<sup>23</sup> = 8,388,608 = 8192 KiB (for file sizes between 8 GiB - 16 GiB)
- 2<sup>24</sup> = 16,777,216 = 16384 KiB (for file sizes between 16 GiB - 512 GiB) (This is the max you should ever have to use.)
- 2<sup>25</sup> = 33,554,432 = 32768 KiB (Note that uTorrent versions before 3.x CANNOT load torrents with this or higher piece size)

!!! example
``` bash
mktorrent -v -p -l 19 -a http://exampletracker.com/announce -o filename.torrent folder_name
```
