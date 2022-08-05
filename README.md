# Modified ElvUI
Original can be found here: https://github.com/tukui-org/ElvUI

I modified this for personal use in TBC. It probably works in Classic Era/SoM too, but I haven't tested it.

## Changes
* Use HealComm as default source for heal prediction.

* Heal prediction timeframe can be configured, default 3s, i.e. only the next HoT tick will be shown.  
Can be changed in the respective Heal Prediction settings for each unit frame type.

* Uses custom logic to show where your direct heal will land chronologically in heal prediction bars. This is obviously limited by latency, but generally does a good job.  
Uses "Personal" and "Others" color set in: UnitFrames -> Colors -> Heal Prediction  
Your HoTs will be treated as "Others" heal and are always shown after your direct heal.

* Blizzard API is used to show incoming heal from people without HealComm. Will always be shown last because timing is unknown. This value will be interpolated if there's a mix of HealComm and non-HealComm sources.  
Color (default blue) can be changed in: UnitFrames -> Colors -> Heal Prediction

* Added tags that show predicted HP after incoming heals (see Available Tags -> Health in ElvUI settings).

* Added non-uniform aura highlight textures. The default uniform "Fill" option makes it impossible to see class colors and I hate it. Using the new options will ignore Blend Mode. To use select `Non-Uniform` or `Non-Uniform BO` in UnitFrames -> Colors -> Debuff Highlighting.  
`Non-Uniform`: Gradient/glow at border and in the center of the health bar.  
`Non-Uniform BO`: Same with clear center.

* Added heal prediction to target of target frame.

* Enabled tank/assist role indicators for raid frames.
