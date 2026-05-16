-- deadline esp+chams ~vana0x1
-- ins=toggle | end=nuke

                                local
                   plr=game:GetService("Players")
                            .LocalPlayer;
                                local
                    cam=workspace.CurrentCamera;
               local rs=game:GetService("RunService");
         local uis=game:GetService("UserInputService");local
               cf=workspace:WaitForChild("characters")
                     ;local Dn=Drawing.new;local
                          In=Instance.new;
                                local
                         rgb=Color3.fromRGB;
                                local
                           V2=Vector2.new;
                                local
                           V3=Vector3.new;
                                local
              aot=Enum.HighlightDepthMode.AlwaysOnTop;
                 local kI=Enum.KeyCode.Insert;local
          kE=Enum.KeyCode.End;local hrp="HumanoidRootPart";
            local on=true;local D={};local C={};local cA,
                cR,cF,cI;local function w2v(p) return
                     cam:WorldToViewportPoint(p)
                                end;
                                local
                              function
                               root(m)
                               return
                      m:FindFirstChild(hrp) or
                m:FindFirstChildWhichIsA("BasePart",
              true) end;local function vis(t,s) for _,d
          in pairs(t) do d.Visible=s end end;local function
        mkE(m) if D[m] then return end;local b=Dn("Square");
           b.Thickness=1;b.Filled=false;b.Transparency=1;
              b.Color=rgb(0,255,255);local n=Dn("Text")
                      ;n.Size=13;n.Center=true;
                      n.Outline=true;n.Font=2;
                          n.Color=rgb(255,
                              255,100)
                               ;local
                            t=Dn("Line")
                           ;t.Thickness=1;
                 t.Transparency=.75;t.Color=rgb(255,
             0,0);D[m]={b,n,t} end;local function mkC(m)
          if C[m] then return end;local h=In("Highlight");
      h.FillColor=rgb(255,165,0);h.OutlineColor=rgb(255,200,0);
         h.FillTransparency=.65;h.DepthMode=aot;h.Adornee=m;
             h.Parent=m;C[m]=h end;local function rm(m)
                  local d=D[m];if d then for _,x in
                     pairs(d) do pcall(x.Remove,
                           x) end;D[m]=nil
                                end;
                                local
                          h=C[m];if h then
                     pcall(h.Destroy,h);C[m]=nil
                 end end;local function tick() local
             vp=cam.ViewportSize;local hx=vp.X*.5;local
           by=vp.Y;local me=plr.Character;local mr=me and
      me:FindFirstChild(hrp);local mp=mr and mr.Position;for m,
          d in pairs(D) do local r=m.Parent and root(m);if
             not r or not on then vis(d,false);continue
                  end;local rp,ok=w2v(r.Position);
                      if not ok or rp.Z<0 then
                            vis(d,false);
                              continue
                              end;local
                         wp=r.Position;local
                       tp=w2v(wp+V3(0,2.5,0));
                  local bp=w2v(wp-V3(0,3,0));local
               bh=math.abs(tp.Y-bp.Y);local bw=bh*.6;
            local ty=math.min(tp.Y,bp.Y);d[1].Size=V2(bw,
       bh);d[1].Position=V2(rp.X-bw*.5,ty);d[1].Visible=true;
           local dist=mp and math.floor((wp-mp).Magnitude)
              or 0;d[2].Text=m.Name.." ["..dist.."m]";
                    d[2].Position=V2(rp.X,ty-20);
                       d[2].Visible=true;d[3]
                            .From=V2(hx,
                                by);
                                d[3]
                            .To=V2(rp.X,
                       bp.Y);d[3].Visible=true
                       end end;local function
                reg(m) if root(m) then mkE(m);mkC(m)
             end end;for _,m in ipairs(cf:GetChildren()
        ) do reg(m) end;cA=cf.ChildAdded:Connect(function(m)
              task.wait(.3);if m.Parent then reg(m) end
                end);cR=cf.ChildRemoved:Connect(rm);
                  cF=rs.RenderStepped:Connect(tick)
                           ;local function
                               nuke()
                                if cF
                                then
                           cF:Disconnect()
                          ;cF=nil end;if cA
                     then cA:Disconnect();cA=nil
                   end;if cR then cR:Disconnect();
              cR=nil end;for _,d in pairs(D) do for _,x
         in pairs(d) do pcall(x.Remove,x) end end;for _,h in
            pairs(C) do pcall(h.Destroy,h) end;for _,m in
               ipairs(cf:GetChildren()) do for _,o in
                  ipairs(m:GetDescendants()) do if
                       o:IsA("Highlight") then
                          pcall(o.Destroy,
                               o) end
                                 end
                              end;D={};
                         C={};on=false end;
                cI=uis.InputBegan:Connect(function(i,
             gp) if gp then return end;if i.KeyCode==kI
           then on=not on;for _,h in pairs(C) do if h and
      h.Parent then h.Enabled=on end end;print("esp",on) elseif
        i.KeyCode==kE then nuke();if cI then cI:Disconnect()
                ;cI=nil end;print("nuked") end end);
                print("loaded // ins=tog, end=nuke")

