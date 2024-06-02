---@meta AffineFrame

---@class AffineFrame # An AFFINE frame is one frame of an animation, with lines and svs that make up that frame.
---@field lines TimingPointInfo[] # The timing lines of the frame.
---@field svs SliderVelocityInfo[] # The SVs (usually displacements) of the frame.
---@field time number # The time in which the frame was generated.
