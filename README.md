<h1>Jung Rhythm</h1>
<img width="165" height="165" align="right" src="https://github.com/DerekPascarella/JungRhythm-EnglishPatchSaturn/blob/main/images/cover.png?raw=true">English translation patch for the rhythm game "Jung Rhythm" on the Sega Saturn.
<br><br>
"Jung Rhythm" is a rhythm game for the Sega Saturn, often compared to "PaRappa the Rapper" for some of its similarities, although according to records, both games were in development simultaneously.
<br><br>
The player takes the role of Vanilla Essence, a young girl who dreams of being a star. The story follows her quest from eating breakfast through to a duet with her favorite superstar, the earth-loving rocker, Chorking!
<br><br>
The gameplay itself takes the form of call-and-response dance and song duets with various characters, where the other characters will sing a line and the player is asked to repeat it. Lyrics appear at the top of the screen, while input prompts appear in the first of a pair of bars along the bottom of the screen as they sing. Ad-libbed inputs are also permitted, and there are specific ad-lib segments.
<br><br>
Vanilla Essence's performance is then graded in five categories and given an overall score. If players score high enough, they're allowed to continue to the next story segment. Between story segments there is a short full-motion video cutscene connecting the dots.
<br><br>
The game additionally includes a practice mode, as well as a two-player "BATTLE" mode, where players can compare their skills.
<br><br>
The latest version of this patch is <a href="https://github.com/DerekPascarella/JungRhythm-EnglishPatchSaturn/releases/download/1.0/Jung.Rhythm.English.-.v1.0.zip">1.0</a>.

<h2>Table of Contents</h2>

1. [Patching Instructions](#patching-instructions)
2. [Credits](#credits)
3. [Release Changelog](#release-changelog)
4. [What's Changed](#whats-changed)
5. [About the Game](#about-the-game)
8. [How to Play](#how-to-play)
9. [Good and Bad Endings](#good-and-bad-endings)
10. [FMV Playlist](#fmv-playlist)

<h2>Patching Instructions</h2>
There are two options available for those wishing to enjoy this English translation patch.

<h3>Sega Saturn Patcher</h3>
<img align="right" width="250" height="187" src="https://github.com/DerekPascarella/JungRhythm-EnglishPatchSaturn/blob/main/images/patcher.png?raw=true">The SSP file shipped with this patch is for use with <a href="https://drive.google.com/uc?export=download&id=1815dZRP0_N3TihjsHBepPuJN1hopiDLG">Sega Saturn Patcher</a> version 1.95 or newer. While the <a href="http://redump.org/disc/26548/">Redump version of the game</a> was used as the source disc image during development and testing, Sega Saturn Patcher is a flexible utility that accepts multiple disc image formats as input.
<br><br>
After launching the utility, follow the steps below to apply the English translation patch.
<br><br>
<ol type="1">
  <li>Click "Select Saturn Game" at the top of the window.</li>
  <li>Click "CD Image", then navigate to the location of your original source disc image and click "Open" at the bottom right of the dialogue window.</li>
  <li>Click "+ Game Patch (SSP)" on the middle-right of the window.</li>
  <li>Navigate to the location of <tt>Jung Rhythm (English - v1.0).ssp</tt> and then click "Open" at the bottom right of the dialogue window.</li>
  <li>Check the box at the bottom-right of the window labeled "Separate Track Files (if applicable)".</li>
  <li>Click "Patch Image" at the bottom-right of the window and then navigate to the target folder where patched disc image should be stored.</li>
    <ul>
      <li>MODE, Satiator, and Fenrir users should select "CUE/BIN" under the "Save as type" dropdown.</li>
      <li>Rhea/Phoebe users should select "CCD/IMG" under the "Save as type" dropdown.
      <li>Users burning to CD-R should select "CUE/BIN" under the "Save as type" dropdown, as this format is universally compatible with all popular burning software.</li>
      <li>Emulator users should select "CUE/BIN" under the "Save as type" dropdown, as this format is universally compatible with all popular emulators.</li>
    </ul>
  <li>Once patching is complete, click "X" at the top-right of the window.</li>
</ol>

<h3>XDelta</h3>
<img align="right" width="250" src="https://i.imgur.com/r4b04e7.png">The XDelta patch file shipped with this release can be used with any number of Delta utilities, such as <a href="https://www.romhacking.net/utilities/704/">Delta Patcher</a>. Ensure that the <a href="http://redump.org/disc/26548/">Redump version of the game</a> is used as the source disc image, where <tt>Jung Rhythm (Japan) (Track 01).bin</tt> has an MD5 checksum of <tt>2A8828A0E29CF17ED045BDAF29A6E761</tt>.
<br><br>
<ol type="1">
<li>Click the settings icon (appears as a gear), then enable "Checksum validation" and disable "Backup original file".</li>
<li>Click the "Original file" browse icon and select the unmodified <tt>Jung Rhythm (Japan) (Track 01).bin</tt> file.</li>
<li>Click the "XDelta patch" browse icon and select the <tt>Jung Rhythm (English - v1.0).xdelta</tt> patch file.</li>
<li>Click "Apply patch" to generate the patched <tt>.bin</tt> in the same folder containing original <tt>.bin</tt>.</li>
<li>Verify that the patched <tt>.bin</tt> has an MD5 checksum of <tt>25F96A0FD0FA64A4AD6D9584B6824354</tt>.</li>
</ol>

<h2>Credits</h2>
<ul>
  <li>
    <b>Programming / Hacking</b>
  </li>
  <ul>
    <li>Derek Pascarella (ateam)</li>
  </ul>
  <br>
  <li>
    <b>Translation</b>
  </li>
  <ul>
    <li>wiredcrackpot</li>
  </ul>
  <br>
  <li>
    <b>Audio / Video</b>
  </li>
  <ul>
    <li>Shadowmask</li>
  </ul>
  <br>
  <li>
    <b>Graphics</b>
  </li>
  <ul>
    <li>Malenko</li>
  </ul>
</ul>

<h2>Release Changelog</h2>
<ul>
 <li>Version 1.0 (2024-04-20)</li>
 <ul>
  <li>Initial release.</li>
 </ul>
</ul>

<h2>What's Changed</h2>
<ul>
 <li>New single-byte character encoding code and a new font have been implemented.</li>
 <li>All text has been translated into English, including song lyrics.</li>
 <li>All graphics have been translated into English and re-rendered.</li>
 <li>All cutscene videos have been translated into English, subtitled, and re-rendered.</li>
</ul>

<h2>About the Game</h2>
<table>
<tr>
<td><b>Title</b></td>
<td>Jung Rhythm (じゃんぐリズム)</td>
</tr>
<td><b>Developer</b></td>
<td>Altron Corporation</td>
</tr>
<tr>
<td><b>Publisher</b></td>
<td>Altron Corporation</td>
</tr>
<tr>
<td><b>Release Date</b></td>
<td>January 15th, 1998</td>
</tr>
<tr>
<td><b>Supported Peripherals</b></td>
<td>Control Pad, Back-Up RAM Cartridge</td>
</tr>
</tr>
</table>

<h2>How to Play</h2>
<img align="right" src="https://github.com/DerekPascarella/JungRhythm-EnglishPatchSaturn/blob/main/images/screenshot_1.png?raw=true" width="290" height="210">"Jung Rhythm" features six playable stages (as well as a bonus end stage), as well as a two-player "BATTLE" mode, and a training mode. Each stage requires players to mimic the instructor, following along with button presses in time with the music.
<br><br>
In two-player "BATTLE" mode, there are two gameplay styles to choose from: "RHYTHM JUNGLE" and "BATTLE JUNGLE". The former features a back-and-forth where each player takes turns, whereas the latter features a separate bar on the bottom of the screen for both players to sing and dance at the same time.
<br><br>
Throughout each single-player stage, a message appears one or more times informing players that it's time to freestyle ("Ad-libbing"). While any combination of buttons will help add to one's score, below are a list of finishing moves for the only playable character, Vanilla Essence.
<br>
<h3>Vanilla's Finishing Moves</h3>
<table>
  <tr>
    <td>Vani-Somersault</td>
    <td>Down + Up + C</td>
  </tr>
  <tr>
    <td>Vani-Riser</td>
    <td>Right + Down + Right + A</td>
  </tr>
  <tr>
    <td>Vanilla Screw</td>
    <td>Left + Right + Down + Left + B</td>
  </tr>
</table>

<br>
In two-player "BATTLE" mode, if selecting the "BATTLE JUNGLE" option, a gague will fill and a symbol will appear signifying that the player is able to perform a finishing move, each of which is listed below.

<h3>All Characters' Finishing Moves</h3>

<table>
  <tr>
    <td><b>Character</b></td>
    <td><b>Move Name</b></td>
    <td><b>Button Combination</b></td>
  </tr>
  <tr>
    <td>Vanilla Essence</td>
    <td>Vani-Somersault</td>
    <td>Down + Up + C</td>
  </tr>
  <tr>
    <td>Vanilla Essence</td>
    <td>Vani-Riser</td>
    <td>Right + Down + Right + A</td>
  </tr>
  <tr>
    <td>Vanilla Essence</td>
    <td>Vanilla Screw</td>
    <td>Left + Right + Down + Left + B</td>
  </tr>
  <tr>
    <td>Dorian Bavarois</td>
    <td>Dori-Riser</td>
    <td>Right + Down + Right + A</td>
  </tr>
  <tr>
    <td>Mama Essence</td>
    <td>Egg Crusher</td>
    <td>Left + Down + Right + B</td>
  </tr>
  <tr>
    <td>Picasso</td>
    <td>Arts Bomber</td>
    <td>Right + Left + Right + A</td>
  </tr>
  <tr>
    <td>Gonzo Enka</td>
    <td>Flower Path of Enka</td>
    <td>C + Down + B + Down</td>
  </tr>
  <tr>
    <td>Coco Pine</td>
    <td>Funky Beat</td>
    <td>Left + Up + Right + B</td>
  </tr>
  <tr>
    <td>Mr. Chorking</td>
    <td>Ecology Shower</td>
    <td>Down + Left + Down + Left + A</td>
  </tr>
</table>


<h2>Good and Bad Endings</h2>
<img align="right" src="https://github.com/DerekPascarella/JungRhythm-EnglishPatchSaturn/blob/main/images/screenshot_2.png?raw=true" width="290" height="203">If players receive a score of 465 or better on stage six, where Vanilla dances with Mr. Chorking on stage, they will be rewarded with an additional bonus stage after fans demand an encore from Mr. Chorking.
<br><br>
Additionally, an alternative final video sequence will play, dubbed as the "good ending". This version of the ending is also the only way to see the staff credits video.
<br><br>
If players are unable to achieve a sufficient score to see this ending during their first playthrough of the game, they can use the "LOAD" option on the main menu to replay stage six and try again.

<h2>FMV Playlist</h2>
All subtitled FMVs from the game have been uploaded to YouTube and added to a single playlist. Players who are unable to achieve the good ending can watch the <b>ENC</b> and <b>ED2</b> videos, should they so desire.
<br><br>
Playlist link: <a href="https://www.youtube.com/playlist?list=PLzv9q1kzOXvp4K-3cyzAC20wYJunXK2A9">https://www.youtube.com/playlist?list=PLzv9q1kzOXvp4K-3cyzAC20wYJunXK2A9</a>
