
using Distributions
using Random, Test



function test_location_scale_normal(μ::Float64,σ::Float64,μD::Float64,σD::Float64)
    ρ = Normal(μD,σD)
    d = LocationScale(μ,σ,ρ)
    dref = Normal(μ+σ*μD,σ*σD)

    @test minimum(d) == minimum(dref)
    @test maximum(d) == maximum(dref)

    #### Conversions

    @test convert(LocationScale{Float16}, μ, σ, ρ) == LocationScale{Float16,typeof(ρ)}(Float16(μ), Float16(σ), ρ)
    @test convert(LocationScale{Float16}, d) == LocationScale{Float16,typeof(ρ)}(Float16(μ), Float16(σ), ρ)

    @test location(d) == μ
    @test scale(d) == σ
    @test params(d) == (μ,σ,ρ)
    @test partype(d) == Float64

    #### Statistics

    @test mean(d) ≈ mean(dref)
    @test median(d) ≈ median(dref)
    @test mode(d) ≈ mode(dref)
    @test modes(d) ≈ modes(dref)

    @test var(d) ≈ var(dref)
    @test std(d) ≈ std(dref)
    @test skewness(d) ≈ skewness(dref)
    @test kurtosis(d) ≈ kurtosis(dref)

    @test isplatykurtic(d) == isplatykurtic(dref)
    @test isleptokurtic(d) == isleptokurtic(dref)
    @test ismesokurtic(d) == ismesokurtic(dref)

    @test entropy(d) ≈ entropy(dref)
    @test mgf(d,-0.1) ≈ mgf(dref,-0.1)

    #### Evaluation & Sampling

    insupport(d,0.4) == insupport(dref,0.4)
    @test pdf(d,0.1) ≈ pdf(dref,0.1)
    @test pdf.(Ref(d),2:4) ≈ pdf.(Ref(dref),2:4)
    @test logpdf(d,0.4) ≈ logpdf(dref,0.4)
    @test loglikelihood(d,[0.1,0.2,0.3]) ≈ loglikelihood(dref,[0.1,0.2,0.3])
    @test cdf(d,μ-0.4) ≈ cdf(dref,μ-0.4)
    @test logcdf(d,μ-0.4) ≈ logcdf(dref,μ-0.4)
    @test ccdf(d,μ-0.4) ≈ ccdf(dref,μ-0.4) atol=1e-100
    @test logccdf(d,μ-0.4) ≈ logccdf(dref,μ-0.4) atol=1e-16
    @test quantile(d,0.1) ≈ quantile(dref,0.1)
    @test quantile(d,0.5) ≈ quantile(dref,0.5)
    @test quantile(d,0.9) ≈ quantile(dref,0.9)
    @test cquantile(d,0.1) ≈ cquantile(dref,0.1)
    @test cquantile(d,0.5) ≈ cquantile(dref,0.5)
    @test cquantile(d,0.9) ≈ cquantile(dref,0.9)
    @test invlogcdf(d,log(0.2)) ≈ invlogcdf(dref,log(0.2))
    @test invlogcdf(d,log(0.5)) ≈ invlogcdf(dref,log(0.5))
    @test invlogcdf(d,log(0.8)) ≈ invlogcdf(dref,log(0.8))
    @test invlogccdf(d,log(0.2)) ≈ invlogccdf(dref,log(0.2))
    @test invlogccdf(d,log(0.5)) ≈ invlogccdf(dref,log(0.5))
    @test invlogccdf(d,log(0.8)) ≈ invlogccdf(dref,log(0.8))

    r = Array{Float64}(undef, 100000)
    rand!(d,r)
    @test mean(r) ≈ mean(dref) atol=0.01
    @test std(r) ≈ std(dref) atol=0.01
    @test cf(d, -0.1) ≈ cf(dref,-0.1)
    @test gradlogpdf(d, 0.1) ≈ gradlogpdf(dref, 0.1)

end

println("\ttesting LocationScale")
test_location_scale_normal(0.3,0.2,0.1,0.2)
test_location_scale_normal(-0.3,0.1,-0.1,0.3)
test_location_scale_normal(1.3,0.4,-0.1,0.5)
